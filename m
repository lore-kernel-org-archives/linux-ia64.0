From: Keith Owens <kaos@sgi.com>
Date: Tue, 03 Feb 2004 01:27:38 +0000
Subject: Re: [patch] 0/5 2.4.25-pre7 mca.c cleanup
Message-Id: <3163.1075771658@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <6503.1075705201@kao2.melbourne.sgi.com>
In-Reply-To: <6503.1075705201@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 02 Feb 2004 16:36:17 -0800, 
Ben Woodard <woodard@redhat.com> wrote:
>Jim Garlick and I have both been trying to make the smallest changes
>possible to fix the problems we have been seeing.

My changes delete all of the unnecessary and racy use of printk() from
mca.c, which should go a long way to fixing the problems that you and
Jim are seeing.  If you still see hangs or problems after my clean up,
please let me know ASAP.

