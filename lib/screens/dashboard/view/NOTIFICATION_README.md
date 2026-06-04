// get all notifications 

curl --request GET \
--url https://hypermart.eshopweb.store/api/delivery-boy/notifications \
--header 'Accept: application/json' \
--header 'Authorization: Bearer 4024|CU5ffHWsMCm8EbautKMhl1qVU9q7U2b4TRRHLOPy5abb7df3'

{
"success": true,
"message": "Notifications retrieved successfully",
"data": {
"notifications": [
{
"id": "fedcf6a6-0632-406c-9a96-98977a23c0e4",
"user_id": 27,
"store_id": null,
"order_id": 837,
"type": "settlement_process",
"sent_to": "delivery_boy",
"title": "Earning Settled",
"message": "Your earning of 255.00 has been settled for Order #837.",
"is_read": false,
"data": {
"title": "Earning Settled",
"message": "Your earning of 255.00 has been settled for Order #837.",
"type": "settlement_process",
"sent_to": "delivery_boy",
"user_id": 27,
"order_id": 837,
"metadata": {
"delivery_boy_assignment_id": 325,
"paid_at": null
}
},
"metadata": {
"delivery_boy_assignment_id": 325,
"paid_at": null
},
"created_at": "2026-02-25T07:11:33.000000Z",
"updated_at": "2026-02-25T07:11:33.000000Z"
},
{
"id": "3318ae85-cb44-46db-aedb-9735daebfa3f",
"user_id": 27,
"store_id": null,
"order_id": null,
"type": "wallet_transaction",
"sent_to": "seller",
"title": "Wallet Deposit",
"message": "A wallet transaction has occurred. Amount: 255.00 USD",
"is_read": false,
"data": {
"title": "Wallet Deposit",
"message": "A wallet transaction has occurred. Amount: 255.00 USD",
"type": "wallet_transaction",
"sent_to": "seller",
"user_id": 27,
"store_id": null,
"order_id": null,
"metadata": {
"wallet_transaction_id": 831,
"transaction_type": "deposit",
"status": "completed"
}
},
"metadata": {
"wallet_transaction_id": 831,
"transaction_type": "deposit",
"status": "completed"
},
"created_at": "2026-02-25T07:11:32.000000Z",
"updated_at": "2026-02-25T07:11:32.000000Z"
},
{
"id": "46ed8f17-bae3-46aa-a91a-3a6bd62ddbea",
"user_id": 27,
"store_id": null,
"order_id": null,
"type": "withdrawal_process",
"sent_to": "delivery_boy",
"title": "Withdrawal Status Updated",
"message": "Your withdrawal of 1.00 updated from Pending to Approved.",
"is_read": false,
"data": {
"title": "Withdrawal Status Updated",
"message": "Your withdrawal of 1.00 updated from Pending to Approved.",
"type": "withdrawal_process",
"sent_to": "delivery_boy",
"user_id": 27,
"order_id": null,
"metadata": {
"withdrawal_request_id": 44,
"previous_status": "pending",
"new_status": "approved"
}
},
"metadata": {
"withdrawal_request_id": 44,
"previous_status": "pending",
"new_status": "approved"
},
"created_at": "2026-02-25T07:11:12.000000Z",
"updated_at": "2026-02-25T07:11:12.000000Z"
},
{
"id": "d038defc-e0ca-45fe-8e2f-38acfa294c93",
"user_id": 27,
"store_id": null,
"order_id": null,
"type": "wallet_transaction",
"sent_to": "seller",
"title": "Wallet Payment",
"message": "A wallet transaction has occurred. Amount: 1.00 USD",
"is_read": false,
"data": {
"title": "Wallet Payment",
"message": "A wallet transaction has occurred. Amount: 1.00 USD",
"type": "wallet_transaction",
"sent_to": "seller",
"user_id": 27,
"store_id": null,
"order_id": null,
"metadata": {
"wallet_transaction_id": 830,
"transaction_type": "payment",
"status": "completed"
}
},
"metadata": {
"wallet_transaction_id": 830,
"transaction_type": "payment",
"status": "completed"
},
"created_at": "2026-02-25T07:11:10.000000Z",
"updated_at": "2026-02-25T07:11:10.000000Z"
},
{
"id": "9a131a94-e11f-46a6-9a29-518c01701556",
"user_id": 27,
"store_id": null,
"order_id": null,
"type": "withdrawal_request",
"sent_to": "delivery_boy",
"title": "Withdrawal Request Submitted",
"message": "Your withdrawal request of 1.00 has been submitted.",
"is_read": false,
"data": {
"title": "Withdrawal Request Submitted",
"message": "Your withdrawal request of 1.00 has been submitted.",
"type": "withdrawal_request",
"sent_to": "delivery_boy",
"user_id": 27,
"order_id": null,
"metadata": {
"withdrawal_request_id": 44,
"status": "pending"
}
},
"metadata": {
"withdrawal_request_id": 44,
"status": "pending"
},
"created_at": "2026-02-25T07:10:20.000000Z",
"updated_at": "2026-02-25T07:10:20.000000Z"
},
{
"id": "83e0847f-ee06-4450-b22b-6e158a7e1d04",
"user_id": 27,
"store_id": null,
"order_id": 848,
"type": "delivery",
"sent_to": "delivery_boy",
"title": "Order Ready For Pickup",
"message": "Order #848 is ready for pickup in your zone.",
"is_read": false,
"data": {
"title": "Order Ready For Pickup",
"message": "Order #848 is ready for pickup in your zone.",
"type": "delivery",
"sent_to": "delivery_boy",
"user_id": 27,
"order_id": 848,
"metadata": {
"order_id": 848,
"order_slug": "order-1772002283-84",
"zone_id": 1,
"shipping_latitude": "23.25045803",
"shipping_longitude": "69.66241535"
}
},
"metadata": {
"order_id": 848,
"order_slug": "order-1772002283-84",
"zone_id": 1,
"shipping_latitude": "23.25045803",
"shipping_longitude": "69.66241535"
},
"created_at": "2026-02-25T06:52:43.000000Z",
"updated_at": "2026-02-25T06:52:43.000000Z"
},
{
"id": "89f59592-b937-4feb-a740-e57c77f6542b",
"user_id": 27,
"store_id": null,
"order_id": 753,
"type": "delivery",
"sent_to": "delivery_boy",
"title": "Order Ready For Pickup",
"message": "Order #753 is ready for pickup in your zone.",
"is_read": false,
"data": {
"title": "Order Ready For Pickup",
"message": "Order #753 is ready for pickup in your zone.",
"type": "delivery",
"sent_to": "delivery_boy",
"user_id": 27,
"order_id": 753,
"metadata": {
"order_id": 753,
"order_slug": "order-1771243424-1",
"zone_id": 1,
"shipping_latitude": "23.25643125",
"shipping_longitude": "69.64324313"
}
},
"metadata": {
"order_id": 753,
"order_slug": "order-1771243424-1",
"zone_id": 1,
"shipping_latitude": "23.25643125",
"shipping_longitude": "69.64324313"
},
"created_at": "2026-02-25T06:50:53.000000Z",
"updated_at": "2026-02-25T06:50:53.000000Z"
},
{
"id": "206670bb-13e6-43b7-aba5-23d52f4ce0bb",
"user_id": 27,
"store_id": null,
"order_id": 847,
"type": "settlement_create",
"sent_to": "delivery_boy",
"title": "New Earning Added",
"message": "Earning amount 255.00 added for Order #847.",
"is_read": false,
"data": {
"title": "New Earning Added",
"message": "Earning amount 255.00 added for Order #847.",
"type": "settlement_create",
"sent_to": "delivery_boy",
"user_id": 27,
"order_id": 847,
"metadata": {
"delivery_boy_assignment_id": 330,
"total_earnings": 255
}
},
"metadata": {
"delivery_boy_assignment_id": 330,
"total_earnings": 255
},
"created_at": "2026-02-25T06:37:26.000000Z",
"updated_at": "2026-02-25T06:37:26.000000Z"
},
{
"id": "54a41d01-e895-4b5d-ad21-6a0012840217",
"user_id": 27,
"store_id": null,
"order_id": 847,
"type": "delivery",
"sent_to": "delivery_boy",
"title": "Order Ready For Pickup",
"message": "Order #847 is ready for pickup in your zone.",
"is_read": false,
"data": {
"title": "Order Ready For Pickup",
"message": "Order #847 is ready for pickup in your zone.",
"type": "delivery",
"sent_to": "delivery_boy",
"user_id": 27,
"order_id": 847,
"metadata": {
"order_id": 847,
"order_slug": "order-1772001269-84",
"zone_id": 1,
"shipping_latitude": "23.25045803",
"shipping_longitude": "69.66241535"
}
},
"metadata": {
"order_id": 847,
"order_slug": "order-1772001269-84",
"zone_id": 1,
"shipping_latitude": "23.25045803",
"shipping_longitude": "69.66241535"
},
"created_at": "2026-02-25T06:36:30.000000Z",
"updated_at": "2026-02-25T06:36:30.000000Z"
},
{
"id": "bee4fb62-d726-459d-bcfd-8e0ec57fcbb3",
"user_id": 27,
"store_id": null,
"order_id": null,
"type": "wallet_transaction",
"sent_to": "seller",
"title": "Wallet Deposit",
"message": "A wallet transaction has occurred. Amount: 188.50 USD",
"is_read": false,
"data": {
"title": "Wallet Deposit",
"message": "A wallet transaction has occurred. Amount: 188.50 USD",
"type": "wallet_transaction",
"sent_to": "seller",
"user_id": 27,
"store_id": null,
"order_id": null,
"metadata": {
"wallet_transaction_id": 829,
"transaction_type": "deposit",
"status": "completed"
}
},
"metadata": {
"wallet_transaction_id": 829,
"transaction_type": "deposit",
"status": "completed"
},
"created_at": "2026-02-25T06:27:21.000000Z",
"updated_at": "2026-02-25T06:27:21.000000Z"
},
{
"id": "c608b359-d0ce-49df-a38f-69ca99ab4083",
"user_id": 27,
"store_id": null,
"order_id": 757,
"type": "delivery",
"sent_to": "delivery_boy",
"title": "Order Ready For Pickup",
"message": "Order #757 is ready for pickup in your zone.",
"is_read": false,
"data": {
"title": "Order Ready For Pickup",
"message": "Order #757 is ready for pickup in your zone.",
"type": "delivery",
"sent_to": "delivery_boy",
"user_id": 27,
"order_id": 757,
"metadata": {
"order_id": 757,
"order_slug": "order-1771308998-1",
"zone_id": 1,
"shipping_latitude": "23.25643125",
"shipping_longitude": "69.64324313"
}
},
"metadata": {
"order_id": 757,
"order_slug": "order-1771308998-1",
"zone_id": 1,
"shipping_latitude": "23.25643125",
"shipping_longitude": "69.64324313"
},
"created_at": "2026-02-25T06:21:16.000000Z",
"updated_at": "2026-02-25T06:21:16.000000Z"
},
{
"id": "9d18797c-c9b3-4fb0-988d-dbdf7b7cf624",
"user_id": 27,
"store_id": null,
"order_id": 840,
"type": "return_order",
"sent_to": "delivery_boy",
"title": "New Return Order Available",
"message": "A new return pickup is available in your zone.",
"is_read": false,
"data": {
"title": "New Return Order Available",
"message": "A new return pickup is available in your zone.",
"type": "return_order",
"sent_to": "delivery_boy",
"user_id": 27,
"order_id": 840,
"order_item_return_id": 35,
"metadata": {
"order_id": 840,
"order_slug": "order-1771921659-84",
"order_item_return_id": 35,
"zone_id": 1,
"shipping_latitude": "23.25045803",
"shipping_longitude": "69.66241535",
"store_id": 1
}
},
"metadata": {
"order_id": 840,
"order_slug": "order-1771921659-84",
"order_item_return_id": 35,
"zone_id": 1,
"shipping_latitude": "23.25045803",
"shipping_longitude": "69.66241535",
"store_id": 1
},
"created_at": "2026-02-25T06:02:48.000000Z",
"updated_at": "2026-02-25T06:02:48.000000Z"
},
{
"id": "b995bc2c-d2ac-4ecb-8c56-5be4acf1897b",
"user_id": 27,
"store_id": null,
"order_id": 758,
"type": "delivery",
"sent_to": "delivery_boy",
"title": "Order Ready For Pickup",
"message": "Order #758 is ready for pickup in your zone.",
"is_read": false,
"data": {
"title": "Order Ready For Pickup",
"message": "Order #758 is ready for pickup in your zone.",
"type": "delivery",
"sent_to": "delivery_boy",
"user_id": 27,
"order_id": 758,
"metadata": {
"order_id": 758,
"order_slug": "order-1771309044-1",
"zone_id": 1,
"shipping_latitude": "23.25643125",
"shipping_longitude": "69.64324313"
}
},
"metadata": {
"order_id": 758,
"order_slug": "order-1771309044-1",
"zone_id": 1,
"shipping_latitude": "23.25643125",
"shipping_longitude": "69.64324313"
},
"created_at": "2026-02-25T05:34:06.000000Z",
"updated_at": "2026-02-25T05:34:06.000000Z"
},
{
"id": "f460b647-b051-47fe-8c8a-1da3d770b4db",
"user_id": 27,
"store_id": null,
"order_id": 759,
"type": "delivery",
"sent_to": "delivery_boy",
"title": "Order Ready For Pickup",
"message": "Order #759 is ready for pickup in your zone.",
"is_read": false,
"data": {
"title": "Order Ready For Pickup",
"message": "Order #759 is ready for pickup in your zone.",
"type": "delivery",
"sent_to": "delivery_boy",
"user_id": 27,
"order_id": 759,
"metadata": {
"order_id": 759,
"order_slug": "order-1771311691-1",
"zone_id": 1,
"shipping_latitude": "23.25643125",
"shipping_longitude": "69.64324313"
}
},
"metadata": {
"order_id": 759,
"order_slug": "order-1771311691-1",
"zone_id": 1,
"shipping_latitude": "23.25643125",
"shipping_longitude": "69.64324313"
},
"created_at": "2026-02-25T05:32:27.000000Z",
"updated_at": "2026-02-25T05:32:27.000000Z"
}
],
"pagination": {
"current_page": 1,
"last_page": 1,
"per_page": 15,
"total": 14
}
}
}

// unread count 

curl --request GET \
--url https://hypermart.eshopweb.store/api/delivery-boy/notifications/unread-count \
--header 'Accept: application/json' \
--header 'Authorization: Bearer 4024|CU5ffHWsMCm8EbautKMhl1qVU9q7U2b4TRRHLOPy5abb7df3'

{
"success": true,
"message": "Unread count retrieved successfully",
"data": {
"unread_count": 14
}
}

// mark all read

curl --request POST \
--url https://hypermart.eshopweb.store/api/delivery-boy/notifications/mark-all-read \
--header 'Accept: application/json' \
--header 'Authorization: Bearer 4024|CU5ffHWsMCm8EbautKMhl1qVU9q7U2b4TRRHLOPy5abb7df3' \
--header 'Content-Type: application/json'

{
"success": true,
"message": "All notifications marked as read",
"data": []
}


// mark a single as read

curl --request POST \
--url https://hypermart.eshopweb.store/api/delivery-boy/notifications/c97b1a6e-629d-4d87-890b-f52827eb703c/read \
--header 'Accept: application/json' \
--header 'Authorization: Bearer 4024|CU5ffHWsMCm8EbautKMhl1qVU9q7U2b4TRRHLOPy5abb7df3' \
--header 'Content-Type: application/json'

{
"success": true,
"message": "Notification marked as read",
"data": []
}

// mark single as un-read

curl --request POST \
--url https://hypermart.eshopweb.store/api/delivery-boy/notifications/c97b1a6e-629d-4d87-890b-f52827eb703c/unread \
--header 'Accept: application/json' \
--header 'Authorization: Bearer 4024|CU5ffHWsMCm8EbautKMhl1qVU9q7U2b4TRRHLOPy5abb7df3' \
--header 'Content-Type: application/json'

{
"success": true,
"message": "Notification marked as unread",
"data": []
}