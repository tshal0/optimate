import { Module } from '@nestjs/common';
import { ProductsController } from '../products/products.controller';
import { HealthController } from './health.controller';

@Module({
  controllers: [HealthController],
})
export class HealthModule {}
