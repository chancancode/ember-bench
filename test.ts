import { InitialRenderBenchmark, InitialRenderSamples, ITab, Runner } from "chrome-tracing";
import * as fs from "fs";

const BASE_PORT = 9292;

let browserOpts = process.env.CHROME_BIN ? {
  type: "exact",
  executablePath: process.env.CHROME_BIN
} : {
  type: "system"
};

let experiments = JSON.parse(fs.readFileSync('config/experiments.json', 'utf8'));

async function sleep(ms) {
  await new Promise(resolve => setTimeout(resolve, 2500));
}

class EmberBench extends InitialRenderBenchmark {
  static all(): EmberBench[] {
    return experiments.map((experiment, i) => {
      let { name } = experiment;
      let port = BASE_PORT + i;
      return new EmberBench(name, port);
    });
  }

  private port: number;
  private url: string;

  constructor(name: string, port: number) {
    let url = `http://localhost:${port}/?perf.tracing`;

    super({
      name,
      url,
      markers: [
        { start: "beforeVendor",   label: "0-vendor"  },
        { start: "beforeApp",      label: "1-app"     },
        { start: "afterApp",       label: "2-boot"    },
        { start: "willTransition", label: "3-routing" },
        { start: "didTransition",  label: "4-render"  },
        { start: "beforePaint",    label: "5-paint"   }
      ],
      browser: browserOpts
    });

    this.port = port;
    this.url = url;
  }

  async warm(tab: ITab): Promise<void> {
    let { port, url } = this;

    await tab.navigate(`http://localhost:${port}/preload.html`, true);

    await sleep(2500);

    await tab.navigate(url, true);

    await sleep(2500);

    await tab.navigate(url, true);

    await sleep(2500);

    await tab.navigate(url, true);

    await sleep(2500);
  }
}

new Runner(EmberBench.all())
.run(50)
.then(results => {
  results.forEach(result => {
    fs.writeFileSync(`results/${result.set}.json`, JSON.stringify(result))
  });
}).catch(err => {
  console.error(err.stack);
  process.exit(1);
});
