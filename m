From: Matthew Wilcox <willy@debian.org>
Date: Thu, 18 Dec 2003 12:14:56 +0000
Subject: Re: Latest 2.4 IA64 Baseline (Bjorn) + Latest ACPI testing report
Message-Id: <marc-linux-ia64-107174972219098@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106863619315583@msgid-missing>
In-Reply-To: <marc-linux-ia64-106863619315583@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Dec 18, 2003 at 10:42:04AM +0800, Yu, Luming wrote:
> >No, you don't understand how resources work.  When device drivers request
> >them, they're marked as busy.  When busses claim them, they're marked
> >as not-busy.  
> 
>   I didn't find the busy flag for resources you mentioned is being used
> in request_resource function.

That's right, it's used in request_region().

>   Actually, based on whether there is a resource conflict happened,
> request_resource determine whether return -EBUSY . (2.6/kernel/resources.c)

request_resource() is used when you know what the parent resource is.
It's assumed to be not-busy; all it's checking for are existing children
of the parent resource which would conflict.

>   According to comments of code, insert_resource is equivalent of request_resource when no conflict happens. If a conflict happens, and the
> conflicting resources entirely fit within the range of the new resource, then the new resource is inserted and the conflicting resources become
> childs of the new resource. 

Yes, I wrote that comment ;-)

>   Obviously, if device drivers want to consume some resources, then they cannot use insert_resource, because insert_resource will not report conflict.

Right, device drivers wouldn't use either request_resource or insert_resource.
They're used by the bus drivers which know a lot more about the system
topology than device drivers (which in general do not care).

>   To anyone using request_resource to consume some resources, how to handle
> conflict situation? If this conflict is between resources supplier (BUS
> device) and resources consumer (Device ) , then device driver should ignore
> this conflict, because it's not a true conflict.

Drivers never see a conflict because they use request_region() which handles
the resource hierarchy for them.

Look at the patch I sent earlier in the thread.  We change the bus driver
to call insert_resource; we don't change the vga driver at all.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
