CREATE TABLE IF NOT EXISTS public.all_sessions
(
    "fullVisitorId" character varying(40) COLLATE pg_catalog."default",
    "channelGrouping" character varying(20) COLLATE pg_catalog."default",
    "time" integer,
    "country" character varying(40) COLLATE pg_catalog."default",
    "city" character varying(40) COLLATE pg_catalog."default",
    "totalTransactionRevenue" integer,
    "transactions" integer,
    "timeOnSite" integer,
    "pageviews" integer,
    "sessionQualityDim" integer,
    "date" date,
    "visitId" integer,
    "type" character varying(10) COLLATE pg_catalog."default",
    "productRefundAmount" integer,
    "productQuantity" integer,
    "productPrice" integer,
    "productRevenue" integer,
    "productSKU" character varying(40) COLLATE pg_catalog."default",
    "v2ProductName" character varying(100) COLLATE pg_catalog."default",
    "v2ProductCategory" character varying(100) COLLATE pg_catalog."default",
    "productVariant" character varying(40) COLLATE pg_catalog."default",
    "currencyCode" character varying(3) COLLATE pg_catalog."default",
    "itemQuantity" integer,
    "itemRevenue" integer,
    "transactionRevenue" integer,
    "transactionId" character varying(20) COLLATE pg_catalog."default",
    "pageTitle" character varying(600) COLLATE pg_catalog."default",
    "searchKeyword" character varying(10) COLLATE pg_catalog."default",
    "pagePathLevel1" character varying(20) COLLATE pg_catalog."default",
    "eCommerceAction_type" integer,
    "eCommerceAction_step" integer,
    "eCommerceAction_option" character varying(20) COLLATE pg_catalog."default"
)


ALTER TABLE IF EXISTS public.all_sessions
    OWNER to postgres