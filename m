From: Keith Owens <kaos@ocs.com.au>
Date: Tue, 04 Nov 2003 10:29:19 +0000
Subject: Re: Page table mapped and identity segments!
Message-Id: <marc-linux-ia64-106794194920991@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106794072219848@msgid-missing>
In-Reply-To: <marc-linux-ia64-106794072219848@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 4 Nov 2003 15:40:06 +0530, 
"Ameya Mitragotri" <ameya.mitragotri@wipro.com> wrote:
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

The book refers to the 2.4 and earlier kernels.  In 2.6 kernels the
kernel code and data lives in region 5, not 7.

