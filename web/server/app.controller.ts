import { Controller, Get, Query } from '@nestjs/common';
import { AppService } from './app.service';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get('health')
  healthCheck(): string {
    return this.appService.getHealth();
  }

  @Get('shopify')
  installShopify(@Query('shop') shop): any {
    return this.appService.getRedirectUri(shop);
  }
  @Get('shopifyAccessToken')
  async getShopifyAccessToken(
    @Query('shop') shop: string,
    @Query('code') code: string,
  ) {
    return await this.appService.getShopifyAccessToken(shop, code);
  }
}
