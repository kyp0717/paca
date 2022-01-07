import { Construct } from 'constructs';
import { App, Chart } from 'cdk8s';
import * as kplus from 'cdk8s-plus-21';

export class MyChart extends Chart {
  constructor(scope: Construct, name: string) {
    super(scope, name);


   

    const pacakey:string = process.env.APCA_API_KEY_ID as string;
    const pacasecret:string = process.env.APCA_API_SECRET_KEY as string;
    const pacaurl:string = process.env.APCA_API_BASE_URL as string;
    
    // const APCA_API_KEY_ID = process.env.APCA_API_KEY_ID;
    // create the yaml file for secret
    const pacaSecret = new kplus.Secret(this, 'Secret');
    pacaSecret.addStringData('paca_key', pacakey);
    pacaSecret.addStringData('paca_secret', pacasecret);
    pacaSecret.addStringData('paca_url', pacaurl);
    
    // create the yaml file for configmap
    const configMap = new kplus.ConfigMap(this, 'Config');
    configMap.addFile(`${__dirname}/example/gettime.py`);

    const deployment = new kplus.Deployment(this, 'Deployment', {
      replicas: 1,
    })
 
    const workDir = '/opt';
    const myctn= deployment.addContainer({
      image: 'docker.io/kyp0717/paca38:latest',
      workingDir: workDir,
      command: ['python', 'gettime.py'],
    });


    const paperSecret = kplus.Secret.fromSecretName(pacaSecret.name);
    myctn.addEnv('APCA_API_KEY_ID', 
                  kplus.EnvValue.fromSecretValue({secret: paperSecret, key: 'paca_key'}));
    myctn.addEnv('APCA_API_SECRET_KEY', 
                  kplus.EnvValue.fromSecretValue({secret: paperSecret, key: 'paca_secret'}));
    myctn.addEnv('APCA_API_BASE_URL', 
                  kplus.EnvValue.fromSecretValue({secret: paperSecret, key: 'paca_url',}));

    myctn.addEnv('PYTHONUNBUFFERED', kplus.EnvValue.fromValue("0"))
    const volume = kplus.Volume.fromConfigMap(configMap);
    myctn.mount(workDir, volume);
    

  }
}

const app = new App();
new MyChart(app, 'learn');
app.synth();
