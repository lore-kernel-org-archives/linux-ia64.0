From: "Yu, Luming" <luming.yu@intel.com>
Date: Thu, 18 Dec 2003 02:42:04 +0000
Subject: RE: Latest 2.4 IA64 Baseline (Bjorn) + Latest ACPI testing report
Message-Id: <marc-linux-ia64-107171536625072@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106863619315583@msgid-missing>
In-Reply-To: <marc-linux-ia64-106863619315583@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> >> I think  "To bus device, resources returned from _CRS method means that bus device will
>> >> supply those resouces to its children devices. So it's unreasonable to call
>> >> request_resource for them."
>> 
>> >That's faulty logic.  Resources can either be busy (used at the leaf
>> >by a driver) or merely containers for other resources (as they are in
>> >this case).
>> 
>> My concern is that if a device driver want to request a resource,
>> but that resource has been allocated by bus device (which supply this resources to its children devices) 
>> then  -EBUSY get returned. Maybe device driver can
>> ignore this error.  But how to detect a real resource conflict  with other device (another resource consumer)?  All of them return -EBUSY.
>
>No, you don't understand how resources work.  When device drivers request
>them, they're marked as busy.  When busses claim them, they're marked
>as not-busy.  

  I didn't find the busy flag for resources you mentioned is being used in request_resource function.

  Actually, based on whether there is a resource conflict happened, request_resource determine whether return -EBUSY . (2.6/kernel/resources.c)

  Does device drivers use different function to request resources with bus device? If they are using same function without any additional information 
, how could request_resource understand this is busses claiming resources, that is device requesting resources?

  According to comments of code, insert_resource is equivalent of request_resource when no conflict happens. If a conflict happens, and the
conflicting resources entirely fit within the range of the new resource, then the new resource is inserted and the conflicting resources become
childs of the new resource. 

  Obviously, if device drivers want to consume some resources, then they cannot use insert_resource, because insert_resource will not report conflict.

  If they use request_resource, and that resources has been claimed by bus devices,  then conflict will get returned. 
 
  To anyone using request_resource to consume some resources, how to handle conflict situation? If this conflict is between resources supplier (BUS device)
and resources consumer (Device ) , then device driver should ignore this conflict, because it's not a true conflict.

  If this conflict is betwwen resources consumer (Device) and resources consumer (another device), then the device driver should think of it as a serious bug.

 But when conflict happend, the device driver have no idea to tell with who it is conflicted.  (Resource consumer, or Resource supplier)

Do you have any idea?

