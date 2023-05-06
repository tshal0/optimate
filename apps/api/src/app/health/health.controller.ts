import { Controller, Get } from '@nestjs/common';

@Controller('health')
export class HealthController {
  // eslint-disable-next-line @typescript-eslint/no-empty-function
  constructor() {}

  @Get()
  async health() {
    return { status: 'OK' };
  }
}
