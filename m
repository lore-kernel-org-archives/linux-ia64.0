From: Christian Hildner <christian.hildner@hob.de>
Date: Tue, 04 Nov 2003 11:00:57 +0000
Subject: Re: Page table mapped and identity segments!
Message-Id: <marc-linux-ia64-106794372722594@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106794072219848@msgid-missing>
In-Reply-To: <marc-linux-ia64-106794072219848@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ameya Mitragotri schrieb:

>Hello,
>I am refering to David's and Stephanes's book on the IA64 linux kernel.
From my understanding, 
>
>1) I can see that the PAGE_OFFSET which designates the start of
>the identity mapped segment starts at 0xe000000000000000 (region 7).
>
>2) This region has the linux kernel text/data/stack segments.
>
>Now after compiling the linux-2.6.0-test5 on an itanium-2 machine,
>the System.map generated contains addresses only starting with
>0xa0000..which means all these lie in the page table mapped segments
>(region 5).
>
>Why is this happening?
>
Kernel mapping has changed in the 2.6 kernel. The kernel is now 
relocatable (needed for new hardware). Because of that it was decided to 
move the kernel outside the identity mapped region. But the virtual to 
physical mappings are nevertheless done with the old mechanism of pinned 
large 64M pages for text and data. See head.S where these mappings are done.

Christian

> 
>
>Apologies if this is too trivial to be asked.
>
>Thanks
>Ameya
>
>-
>To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>  
>


