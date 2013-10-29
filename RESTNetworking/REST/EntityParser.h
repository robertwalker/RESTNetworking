//
//  EntityParser.h
//  TMSMobile
//
//  Created by Robert Walker on 7/29/11.
//  Copyright 2011 Bennett International Group. All rights reserved.
//

//***************************************************************
//  Sample Entity JSON:
//  http://example.com/orders.json
//  [
//      {
//          "created_at":"2011-08-02T12:21:12-04:00",
//          "deliver_at":"2011-08-02T14:45:00-04:00",
//          "height":8.4,
//          "id":1,
//          "length":50.5,
//          "order_number":"123456",
//          "pickup_at":"2011-08-02T12:30:00-04:00",
//          "revenue_terminal":"MCD",
//          "updated_at":"2011-08-02T12:21:12-04:00",
//          "weight":4998.34,
//          "width":14.2
//      }
//  ]
//
//  Sample Entity XML:
//  http://example.com/orders.xml
//  <?xml version="1.0" encoding="UTF-8"?>
//  <orders type="array">
//  	<order>
//  		<id type="integer">1</id>
//  		<order-number>123456</order-number>
//  		<revenue-terminal>MCD</revenue-terminal>
//  		<pickup-at type="datetime">2011-08-02T12:30:00-04:00</pickup-at>
//  		<deliver-at type="datetime">2011-08-02T14:45:00-04:00</deliver-at>
//  		<weight type="float">4998.34</weight>
//  		<length type="float">50.5</length>
//  		<width type="float">14.2</width>
//  		<height type="float">8.4</height>
//  		<created-at type="datetime">2011-08-02T12:21:12-04:00</created-at>
//  		<updated-at type="datetime">2011-08-02T12:21:12-04:00</updated-at>
//  	</order>
//  </orders>
//
//***************************************************************

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface EntityParser : NSObject <NSXMLParserDelegate>

#pragma mark - Object lifecycle

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)theContext;

#pragma mark - Deserialization methods

// JSON
- (void)parseObjectForEntityNamed:(NSString *)entityName fromJSON:(NSData *)json;
- (NSUInteger)parseObjectsForEntityNamed:(NSString *)entityName fromJSON:(NSData *)json;

// XML
- (void)parseObjectForEntityNamed:(NSString *)entityName fromXML:(NSData *)xml;
- (NSUInteger)parseObjectsForEntityNamed:(NSString *)entityName fromXML:(NSData *)xml;

@end
