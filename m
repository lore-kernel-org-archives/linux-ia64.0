From: Keith Owens <kaos@melbourne.sgi.com>
Date: Mon, 03 Dec 2001 08:40:12 +0000
Subject: [Linux-ia64] Re: Announce: kdb v1.9 is available for kernel 2.4.16
Message-Id: <marc-linux-ia64-105590698805578@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805577@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805577@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 3 Dec 2001 08:43:10 +0100, 
Christoph Hellwig <hch@caldera.de> wrote:
>On Mon, Dec 03, 2001 at 05:11:31PM +1100, Keith Owens wrote:
>> This will probably be the last release of kdb using this patch format.
>> I plan to split kdb into a core patch and smaller arch dependent
>> patches, instead of one big patch for each arch.
>
>Why can't you release one kdb patch instead?

Because every architecture except i386 differes from the base kernel.
IA64 has its own large patch set that has to be applied to the main
kernel before kdb can be applied.  Sparc uses the vger kernel tree.
The -ac trees are different again.


