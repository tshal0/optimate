import { Options } from '@mikro-orm/core';
import { ShopEntity } from '../src/app/shops/shop.entity';
import path from 'path';
import { SessionEntity } from '../src/app/session/session.entity';
import { MySqlDriver } from '@mikro-orm/mysql';

const baseDir = path.resolve(__dirname, '../../..');

const config: Options = {
  entities: [ShopEntity, SessionEntity],
  type: 'mysql',
  forceUtcTimezone: true,
  dbName: 'splitfest',
  debug: true,
  host: 'host.docker.internal',
  port: 3306,
  user: 'root',
  password: 'password',
  migrations: {},
};

export default config;
