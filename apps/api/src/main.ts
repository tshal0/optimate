/**
 * This is not a production server yet!
 * This is only a minimal backend to get started.
 */

import '@shopify/shopify-api/adapters/node';
import { Logger, RequestMethod } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';

import { AppModule } from './app/app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, { rawBody: true });
  const globalPrefix = 'api';
  app.enableShutdownHooks();
  app.setGlobalPrefix(globalPrefix, {
    exclude: [
      { path: '', method: RequestMethod.GET },
      { path: '/', method: RequestMethod.GET },
    ],
  });
  const port = process.env.PORT || 8080;
  const host = process.env.HOST || `http://localhost:${port}`;
  const shop = process.env.SHOP;
  await app.listen(port);
  Logger.log(`🚀 Application is running on PORT: ${port}`);
  Logger.log(`🚀 Application is running on: ${host}/${globalPrefix}`);

  Logger.log(`Login using: ${host}/?shop=${shop}`);
  Logger.log(
    `Install using: ${host}/${globalPrefix}/offline/auth?shop=${shop}`
  );
}

bootstrap();
