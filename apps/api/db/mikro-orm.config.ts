import { Options } from '@mikro-orm/core';
import { ShopEntity } from '../src/app/shops/shop.entity';
import { SessionEntity } from '../src/app/session/session.entity';


const port = parseInt(process.env.DB_PORT) || 3306;
const user = process.env.DB_USER || 'root';
const pass = process.env.DB_PASS || 'password';
const dbName = process.env.DB_NAME;
const host = process.env.DB_HOST || 'host.docker.internal';

const config: Options = {
  entities: [ShopEntity, SessionEntity],
  type: 'mysql',
  forceUtcTimezone: true,
  dbName: dbName,
  debug: true,
  host: host,
  port: port,
  user: user,
  password: pass,
  migrations: {},
};

export default config;
