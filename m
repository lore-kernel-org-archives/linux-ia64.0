From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Thu, 03 Jul 2003 23:01:45 +0000
Subject: Re: Early printk is Gone....???
Message-Id: <marc-linux-ia64-105727345722710@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105711058824791@msgid-missing>
In-Reply-To: <marc-linux-ia64-105711058824791@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Martin" = Martin Hicks <mort@wildopensource.com> writes:

Martin> On Wed, Jul 02, 2003 at 11:43:33AM +1000, Peter Chubb wrote:
>> If I clone David's 2.5 tree (or use Linus's tree, same difference)
>> CONFIG_IA64_EARLY_PRINTK is inoperative -- the code to do the work
>> just isn't in the tree.

Martin> I just looked at the latest linux-ia64-2.5 bitkeeper tree and
Martin> it appears to be there.  Note that you cannot use EARLY_PRINTK
Martin> with a Generic kernel anymore.

You're right, it is in David's tree, just not in the to-linus tree or
Linus's tree.  My bad.  Sorry...

Peter C
