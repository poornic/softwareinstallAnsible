INSERT INTO "DELIVERYTYPE" (ID, NAME, DESCRIPTION, PATH, DTYPE) VALUES('1', 'Export to Commerce', 'Export to Commerce CAS Record Store', 'OpenMarket/Xcelerate/PrologActions/Publish/ExportCommerce', 'xmlexport') ;
INSERT INTO "ELEMENTCATALOG" (ELEMENTNAME, URL) VALUES('OpenMarket/Xcelerate/PrologActions/Publish/ExportCommerce/ApproveAssets','OpenMarket/Xcelerate/PrologActions/Publish/ExportCommerce/ApproveAssets.xml') ;
INSERT INTO "ELEMENTCATALOG" (ELEMENTNAME, URL) VALUES('OpenMarket/Xcelerate/PrologActions/Publish/ExportCommece/Default','OpenMarket/Xcelerate/PrologActions/Publish/ExportCommerce/Default.groovy') ;
INSERT INTO "ELEMENTCATALOG" (ELEMENTNAME, URL) VALUES('OpenMarket/Xcelerate/PrologActions/Publish/ExportCommerce/DestEditUI','OpenMarket/Xcelerate/PrologActions/Publish/ExportCommerce/DestEditUI.xml') ;
INSERT INTO "ELEMENTCATALOG" (ELEMENTNAME, URL) VALUES('OpenMarket/Xcelerate/PrologActions/Publish/ExportCommerce/PreApprove','OpenMarket/Xcelerate/PrologActions/Publish/ExportCommerce/PreApprove.xml') ;
INSERT INTO "ELEMENTCATALOG" (ELEMENTNAME, URL) VALUES('OpenMarket/Xcelerate/PrologActions/Publish/ExportCommerce/PreviewApprovedAssets','OpenMarket/Xcelerate/PrologActions/Publish/ExportCommerce/PreviewApprovedAssets.xml') ;
INSERT INTO "ELEMENTCATALOG" (ELEMENTNAME, URL) VALUES('OpenMarket/Xcelerate/PrologActions/Publish/ExportCommerce/PublishApprovedAssets','OpenMarket/Xcelerate/PrologActions/Publish/ExportCommerce/PublishApprovedAssets.groovy') ;
INSERT INTO "ELEMENTCATALOG" (ELEMENTNAME, URL) VALUES('OpenMarket/Xcelerate/PrologActions/Publish/ExportCommerce/Render','OpenMarket/Xcelerate/PrologActions/Publish/ExportCommerce/Render.groovy') ;
INSERT INTO "ELEMENTCATALOG" (ELEMENTNAME, URL) VALUES('OpenMarket/Xcelerate/PrologActions/Publish/ExportCommerce/ShowPublishedAssets','OpenMarket/Xcelerate/PrologActions/Publish/ExportCommerce/ShowPublishedAssets.xml') ;
INSERT INTO "SITECATALOG" (PAGENAME, ROOTELEMENT, PAGELETONLY, CSSTATUS, RESARGS1, PAGECRITERIA, CSCACHEINFO, SSCACHEINFO,ACL) VALUES ('OpenMarket/Xcelerate/PrologActions/Publish/ExportCommerce/Render',
'OpenMarket/Xcelerate/PrologActions/Publish/ExportCommerce/Render', 'F', 'live', 'rendermode=live', 'c,cid,context,d,p,rendermode,site,sitepfx,ft_ss','true,~0', 'true,~0', '*');
commit;
