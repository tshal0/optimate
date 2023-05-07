import { MikroOrmModule } from '@mikro-orm/nestjs';
import { ShopifyAuthModule } from '@nestjs-shopify/auth';
import { ShopifyCoreModule } from '@nestjs-shopify/core';
import { ShopifyGraphqlProxyModule } from '@nestjs-shopify/graphql';
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { databaseConfig } from './config/database.config';
import { ProductsModule } from './products/products.module';
import { SessionModule } from './session/session.module';
import { AfterAuthModule } from './shopify/after-auth/after-auth.module';
import {
  shopifyCoreConfig,
  shopifyOfflineConfig,
  shopifyOnlineConfig,
} from './shopify/config';
import { ShopifyCoreConfigService } from './shopify/services/shopify-core-config.service';
import { ShopifyOfflineConfigService } from './shopify/services/shopify-offline-config.service';
import { ShopifyOnlineConfigService } from './shopify/services/shopify-online-config.service';
import { WebhooksModule } from './shopify/webhooks/webhooks.module';
import { HealthModule } from './health/health.module';
import { AppController } from './app.controller';

@Module({
  controllers: [AppController],
  imports: [
    ConfigModule.forRoot({
      cache: true,
      isGlobal: true,
    }),
    MikroOrmModule.forRootAsync(databaseConfig.asProvider()),
    ShopifyCoreModule.forRootAsync({
      imports: [ConfigModule.forFeature(shopifyCoreConfig), SessionModule],
      useClass: ShopifyCoreConfigService,
    }),
    ShopifyAuthModule.forRootAsyncOffline({
      imports: [ConfigModule.forFeature(shopifyOfflineConfig), AfterAuthModule],
      useClass: ShopifyOfflineConfigService,
    }),
    ShopifyAuthModule.forRootAsyncOnline({
      imports: [ConfigModule.forFeature(shopifyOnlineConfig), AfterAuthModule],
      useClass: ShopifyOnlineConfigService,
    }),
    ShopifyGraphqlProxyModule,
    WebhooksModule,
    ProductsModule,
    HealthModule,
  ],
})
export class AppModule {}
