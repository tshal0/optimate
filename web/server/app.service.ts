/* eslint-disable @typescript-eslint/no-empty-function */
import { Injectable } from '@nestjs/common';
import { ShopsService } from './shops/shops.service';
export interface ShopifyAccessTokenResponse {
  access_token: string;
  scope: string;
}
@Injectable()
export class AppService {
  constructor(private shops: ShopsService) {}
  getHealth(): string {
    return 'Health Check: Service is running';
  }

  getRedirectUri(shop: string): string {
    return `https://${shop}.myshopify.com/admin/oauth/authorize?client_id=1b2fc75a3c80aacc94680b065a7a84b1&scope=read_orders,read_draft_orders,read_products,write_products&redirect_uri=https://5c3e0eca4751.ngrok.app/auth/shopify/callback`;
  }
  async getShopifyAccessToken(shop: string, code: string): Promise<any> {
    const uri = `https://${shop}/admin/oauth/access_token?client_id=1b2fc75a3c80aacc94680b065a7a84b1&client_secret=e19031cdc41bee1c927fe883fc0238a7&code=${code}`;
    console.log(uri);
    let text = '';
    try {
      const resp = await fetch(uri, { method: 'POST' });
      text = await resp.text();

      const data: ShopifyAccessTokenResponse = JSON.parse(text);
      const upsertResp = await this.shops.upsert(shop, data.access_token);
      console.log(upsertResp);
      return {};
    } catch (err) {
      console.error(err);
      if (text.length) throw text;
      throw err;
    }
  }
}
