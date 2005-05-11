From: colin ngam <cngam@sgi.com>
Date: Wed, 11 May 2005 16:05:02 +0000
Subject: Re: [RFC] pcibus_to_node implementation for ia64
Message-Id: <42822D2E.3020708@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0505051707220.6114@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0505051707220.6114@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jesse Barnes wrote:

>On Wednesday, May 11, 2005 8:44 am, colin ngam wrote:
>  
>
>>Fine line here .. a valid node id is always returned and that nodeid
>>is a vaild node id for addressing the bus/devices and may be the only
>>node id you can use to address these buses and devices, except when
>>the IO Brick is dual ported.  It is valid with respect to addressing
>>the bus/devices but may not be "valid" with respect to "having
>>Memory" or "having cpus".  Depends on what you expect :-)  Depends on
>>how you want to use it :-)
>>    
>>
>
>But not valid in the sense that you can pass it to any of the kernel 
>routines that say they take a 'node' argument.  IMO, that's a bug in 
>the implementation of I/O and memoryless nodes in sn2.  As Jack and I 
>discussed last year at OLS (he convinced me of this), a node is any 
>combination of memory, CPUs, and/or I/O.  If I/O nodes (or nodes w/o 
>memory generally) are special cased, we're breaking that assumption, 
>making things harder for every caller and user of nodes.
>  
>
I think we are in agreement here.  They should not be special case - but 
caller and users of node id has to be cognizant that a node does not 
necessary mean it has cpus, memory or both.

Thanks.

colin

