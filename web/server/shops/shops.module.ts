import { Module } from '@nestjs/common';
import { SupabaseModule } from 'server/common/supabase/supabase.module';
import { ShopsController } from './shops.controller';
import { ShopsService } from './shops.service';

@Module({
  imports: [SupabaseModule],
  controllers: [ShopsController],
  providers: [ShopsService],
  exports: [ShopsService],
})
export class ShopsModule {}
