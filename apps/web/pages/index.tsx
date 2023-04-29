import {
  VerticalStack,
  Layout,
  LegacyCard,
  Link,
  Page,
  Text,
} from '@shopify/polaris';

import { ProductsCard } from '../components/ProductsCard';

export default function HomePage() {
  return (
    <Page fullWidth>
      <Layout>
        <Layout.Section>
          <LegacyCard sectioned>
            <VerticalStack gap="4">
              <Text as="h2" variant="headingMd">
                Nice work on building a Shopify app with NX, NestJS, and Next 🎉
              </Text>
            </VerticalStack>
          </LegacyCard>
        </Layout.Section>
        <Layout.Section secondary>
          <ProductsCard />
        </Layout.Section>
      </Layout>
    </Page>
  );
}
