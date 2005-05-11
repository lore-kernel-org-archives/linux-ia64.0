From: colin ngam <cngam@sgi.com>
Date: Wed, 11 May 2005 02:42:36 +0000
Subject: Re: [RFC] pcibus_to_node implementation for ia64
Message-Id: <4281711C.2090109@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0505051707220.6114@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0505051707220.6114@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph Lameter wrote:

Hi Christoph,

>On Tue, 10 May 2005, colin ngam wrote:
>
>  
>
>>>+int sn_pcibus_to_node(struct pci_bus *bus)
>>>+{
>>>+	return nasid_to_cnodeid(NASID_GET(SN_PCIBUS_BUSSOFT(bus)->bs_base));
>>>
>>>
>>>      
>>>
>>The cnodeid returned by the above function can be a node id:
>>    1.  With memory but no cpus - Headless Nodes.
>>    2.  With no memory and no cpus - IO Nodes.
>>    
>>
>
>How do I make the function return the correct result?
>  
>
This is the correct result - with respect to which node the 
bus/device/function is directly connected.  Either than using this 
function in pcibus_to_cpumask(), what other purpose is this routine 
targeted?  I assume you want the node id for memory placement?  If that 
is the case it may return the wrong node id.  If you expect this node id 
to have cpus(to feed the result to get pcibus_to_cpumask()), it may 
return the wrong node id.

Depending on what you want, you have to test the node id to see if it 
contains memory or if it contains cpus or both.

>  
>
>>pcibus_to_cpumask() can return 0 if the node is an ionode - TIO or
>>Headless Node(node with no CPUs but has memory).
>>    
>>
>
>How can I determine that? A return value of 0 would mean that the block
>i/o layer would allocate the control structures on node 0. The correct
>result is -1 if there is no node associated with the device.
>  
>
There is always a node associated with the device - the issue is that 
the node may not have cpu but has memory, or may not have both memory 
and cpu.  I am a little bit confused about your comment above and the 
usage of pcibus_to_cpumask().  Are you using sn_pcibus_to_node() to 
target memory placement and pcibus_to_cpumask() to target interrupt?

Thanks.

colin

>-
>To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>  
>

