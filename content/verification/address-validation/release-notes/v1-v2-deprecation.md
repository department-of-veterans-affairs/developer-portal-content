**Versions 1 and 2 of the Address Validation API are now deprecated.**

We won’t add new features or provide ongoing maintenance for v1 or v2. We’ll continue to honor service-level agreements and consider critical defects, but we discourage using these versions. They’re scheduled for deactivation on **March 31, 2027.**

We’re deprecating these versions because v3 of the Address Validation API is available, offering new features and changes.

- Renamed fields for better integration with the **Contact Information API v2**
- Renamed **GET /cityStateProvince** to **GET /locality** to better reflect the endpoint’s capabilities
- Removed support in the **POST /validate** and **POST /candidate endpoints** for identifying which US Congressional District an address belongs to
- Added support in the **POST /validate** and **POST /candidate endpoints** for country codes defined by the International Standards Organization (ISO) and Federal Information Processing Standards (FIPS)
To learn more, review the [Address Validation API v3 documentation.](https://developer.va.gov/explore/api/address-validation/docs?version=current)
