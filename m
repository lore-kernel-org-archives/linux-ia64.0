From: "Yu, Luming" <luming.yu@intel.com>
Date: Wed, 17 Dec 2003 02:54:09 +0000
Subject: RE: Latest 2.4 IA64 Baseline (Bjorn) + Latest ACPI testing report
Message-Id: <marc-linux-ia64-107162966628766@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106863619315583@msgid-missing>
In-Reply-To: <marc-linux-ia64-106863619315583@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> I think  "To bus device, resources returned from _CRS method means that bus device will
>> supply those resouces to its children devices. So it's unreasonable to call
>> request_resource for them."

>That's faulty logic.  Resources can either be busy (used at the leaf
>by a driver) or merely containers for other resources (as they are in
>this case).

My concern is that if a device driver want to request a resource,
but that resource has been allocated by bus device (which supply this resources to its children devices) 
then  -EBUSY get returned. Maybe device driver can
ignore this error.  But how to detect a real resource conflict  with other device (another resource consumer)?  All of them return -EBUSY.

>> I have a patch for above statement.  Please take http://bugzilla.kernel.org/show_bug.cgi?id85 a look.
>No.  That will lose the information about which areas are under which
>busses, which is rather useful information to have. 

Yes, I agree. 

> For example, when
>PCI needs to allocate resources, if we don't partition the root resource
>amongst the child busses, we could inadvertently allocate resources that
>straddle two PCI busses, and that just won't work.

All resources info returned from _CRS has been saved in pci_root_info->controller->window.  Is it enough?
 
Thanks,
Luming


