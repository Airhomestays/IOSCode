
import Foundation
import Apollo
import SKPhotoBrowser


class viewListingModel{
    
    var listID = 0
    var currencyvalue_from_API_base = ""
    var apollo_headerClient: ApolloClient!
    var viewListingArray = ViewListingDetailsQueryy.Data.ViewListing.Result()
    var reiewListingArray = [UserReviewsQuery.Data.UserReview.Result]()
    var getreviewArray = [GetReviewsListQuery.Data.GetReview.Result]()
    var similarlistingArray = [GetSimilarListingQuery.Data.GetSimilarListing.Result]()
    var propertyReviewArray = [GetPropertyReviewsQuery.Data.GetPropertyReview.Result]()
    var getbillingArray = GetBillingCalculationQueryy.Data.GetBillingCalculation.Result()
    var propertyReviewsCount = 0
    var images = [SKPhotoProtocol]()
    
    public var selectedStartDate: Date?
    public var selectedEndDate: Date?
    
    func createLocalPhotos() -> [SKPhotoProtocol] {
        return (0..<(viewListingArray.listingPhotos?.count ?? 0)).map { (i: Int) -> SKPhotoProtocol in
            let photo = SKPhoto.photoWithImageURL("\(IMAGE_LISTING_MEDIUM)\(viewListingArray.listingPhotos?[i]?.name ?? "")")
            
            return photo
        }
    }
    
    func setupTestData() {
        images = createLocalPhotos()
    }
    
    func viewDetailAPICall(listid:Int, completion: @escaping (GraphQLResult<ViewListingDetailsQueryy.Data>?)->())
    {
        if Utility().isConnectedToNetwork(){
            var viewListQuery = ViewListingDetailsQueryy(listId:listid)
            if(Utility.shared.unpublish_preview_check)
            {
                viewListQuery = ViewListingDetailsQueryy(listId: listid, preview: true)
            }
            else
            {
                viewListQuery = ViewListingDetailsQueryy(listId:listid, preview: false)
            }
            
            apollo_headerClient.fetch(query: viewListQuery,cachePolicy:.fetchIgnoringCacheData){(result,error) in
                if error != nil{
                    completion(nil)
                }else{
                    completion(result)
                }
            }
        }else{
            completion(nil)
        }
    }
    
    func reviewcountAPICall(profileid:Int, completion: @escaping (Bool)->Void)
    {
        let reviewListquery = UserReviewsQuery(ownerType: "others", currentPage: 1, profileId: profileid)
        apollo_headerClient.fetch(query: reviewListquery){(result,error) in
            guard (result?.data?.userReviews?.results) != nil else{
                return
            }
            self.reiewListingArray = (result?.data?.userReviews?.results)! as! [UserReviewsQuery.Data.UserReview.Result]
        }
    }
    
    func getreviewAPICall(listId:Int,hostId:String, completion: @escaping (Bool)->Void){
        let getreviewquery = GetReviewsListQuery(listId: listId, currentPage: 1, hostId: hostId)
        apollo_headerClient.fetch(query: getreviewquery){(result,error) in
            if(result?.data?.getReviews?.status == 200){
                self.getreviewArray = (result?.data?.getReviews?.results!)! as! [GetReviewsListQuery.Data.GetReview.Result]
                if(self.getreviewArray.count > 0){
                    Utility.shared.convertTimeStampToString(timestamp:self.getreviewArray[0].createdAt ?? "",toFormat: "MMMM yyyy")
                }
            }
        }
    }
    
    func similarListingAPICall(lat:Double,lng:Double,lisId:Int,completion: @escaping (Bool)->Void)
    {
        let similarlistingquery = GetSimilarListingQuery(lat: lat, lng: lng, listId: lisId)
        apollo_headerClient.fetch(query: similarlistingquery,cachePolicy:.fetchIgnoringCacheData){(result,error) in
            guard (result?.data?.getSimilarListing?.results) != nil else{
                completion(false)
                return
            }
            self.similarlistingArray = ((result?.data?.getSimilarListing?.results)!) as! [GetSimilarListingQuery.Data.GetSimilarListing.Result]
            completion(true)
        }
    }
    
    func getPropertyReviewsAPICall(lisId:Int, completion: @escaping (Bool)->Void){
        let propertyReviewsQuery = GetPropertyReviewsQuery(currentPage: 1, listId: listID)
        apollo_headerClient.fetch(query: propertyReviewsQuery,cachePolicy:.fetchIgnoringCacheData){(result,error) in
            guard (result?.data?.getPropertyReviews?.results) != nil else{
                completion(false)
                return
            }
            self.propertyReviewsCount = result?.data?.getPropertyReviews?.count ?? 0
            self.propertyReviewArray = ((result?.data?.getPropertyReviews?.results)!) as! [GetPropertyReviewsQuery.Data.GetPropertyReview.Result]
            completion(true)
        }
    }
    
    func billingListAPICall(startDate:String,endDate:String, completion: @escaping (String)->Void)
    {
        var currency = String()
        if(Utility.shared.getPreferredCurrency() != nil &&  Utility.shared.getPreferredCurrency() != "")
        {
            currency = Utility.shared.getPreferredCurrency() != nil ? Utility.shared.getPreferredCurrency()! : currencyvalue_from_API_base
        }
        else{
            currency = currencyvalue_from_API_base
        }
        
        let billingListquery = GetBillingCalculationQueryy(listId:listID, startDate: startDate, endDate: endDate, guests: Utility.shared.guestCountToBeSend, visitors: 0, pets: 0, infants: 0 , convertCurrency:currency)
        apollo_headerClient.fetch(query: billingListquery){(result,error) in
            guard (result?.data?.getBillingCalculation?.result) != nil else{
                if(result?.data?.getBillingCalculation?.errorMessage != nil)
                {
                    completion((result?.data?.getBillingCalculation?.errorMessage ?? ""))
                }
                return
            }
            self.getbillingArray = (result?.data?.getBillingCalculation?.result)!
            Utility.shared.guestCountToBeSend = self.getbillingArray.guests ?? Utility.shared.guestCountToBeSend
            completion("")
    }
        
    }
    
}
