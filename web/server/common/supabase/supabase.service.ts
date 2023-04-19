import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

import { createClient, SupabaseClient } from '@supabase/supabase-js';

@Injectable()
export class SupabaseService {
  private readonly logger = new Logger(SupabaseService.name);
  private static _client: SupabaseClient;

  constructor(private config: ConfigService) {}

  public client() {
    this.logger.log('getting supabase client...');
    if (SupabaseService._client) {
      this.logger.log('client exists - returning');
      return SupabaseService._client;
    }

    this.logger.log('initialising new supabase client');
    this.logger.log(this.config.get('SUPABASE_URL'));
    SupabaseService._client = createClient(
      this.config.get('SUPABASE_URL'),
      this.config.get('SUPABASE_KEY'),
      {
        auth: {
          autoRefreshToken: false,
          detectSessionInUrl: false,
          persistSession: false,
        },
      },
    );
    return SupabaseService._client;
  }
}
