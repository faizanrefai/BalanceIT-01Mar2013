

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "MKStoreObserver.h"

@interface MKStoreManager : NSObject<SKProductsRequestDelegate> {

	NSMutableArray *purchasableObjects;
	MKStoreObserver *storeObserver;	
	
}

@property (nonatomic, retain) NSMutableArray *purchasableObjects;
@property (nonatomic, retain) MKStoreObserver *storeObserver;

- (void) requestProductData;

- (void) buyFeatureA; // expose product buying functions, do not expose
- (void) buyFeatureB; // your product ids. This will minimize changes when you change product ids later

// do not call this directly. This is like a private method
- (void) buyFeature:(NSString*) featureId;

- (void) failedTransaction: (SKPaymentTransaction *)transaction;
-(void) provideContent: (NSString*) productIdentifier;

+ (MKStoreManager*)sharedManager;

+ (BOOL) featureAPurchased;
+ (BOOL) featureBPurchased;

+(void) loadPurchases;
+(void) updatePurchases;

@end
