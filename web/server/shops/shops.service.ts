/* eslint-disable @typescript-eslint/no-empty-function */
import { Injectable } from '@nestjs/common';
import { SupabaseService } from 'server/common/supabase/supabase.service';

@Injectable()
export class ShopsService {
  constructor(private supabase: SupabaseService) {}

  async getAll() {
    const client = this.supabase.client();
    const resp = await client.from('shops').select('id, name, access_token');
    return resp.data;
  }
  async getById(id: string) {
    const client = this.supabase.client();
    const resp = await client
      .from('shops')
      .select('id, name, access_token')
      .filter('id', 'eq', id);
    return resp.data[0];
  }

  async upsert(shop: string, access_token: string) {
    const client = this.supabase.client();
    const exists = await client
      .from('shops')
      .select('id, name, access_token')
      .eq('name', shop);
    console.log(exists);
    if (!exists.data.length) {
      const resp = await client
        .from('shops')
        .insert([{ name: shop, access_token: access_token }])
        .throwOnError();
      return resp;
    } else {
      return exists;
    }
  }
}
