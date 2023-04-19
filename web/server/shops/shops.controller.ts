/* eslint-disable @typescript-eslint/no-empty-function */
import { Controller, Get, Param } from '@nestjs/common';
import { ShopsService } from './shops.service';

@Controller('shops')
export class ShopsController {
  constructor(private shops: ShopsService) {}

  @Get(':id')
  async getShop(@Param('id') id: string): Promise<any> {
    return await this.shops.getById(id);
  }
  @Get()
  async getShops(): Promise<any> {
    const shops = await this.shops.getAll();
    return shops.map((shop) => ({ id: shop.id, name: shop.name }));
  }
}
