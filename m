From: Jes Sorensen <jes@sunsite.dk>
Date: Mon, 30 Jul 2001 22:11:02 +0000
Subject: Re: [Linux-ia64] gcc 3.0 help
Message-Id: <marc-linux-ia64-105590693005955@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005940@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005940@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Ken" = Broadfoot, Ken P <ken.p.broadfoot@intel.com> writes:

Ken> Hello,

Ken> Besides gcc 3.0 and libraries and updated binutils, is there
Ken> anything I need to update on the Redhat 7.1 ia64 seawolf release?

Ken> Do I need an updated glibc for example?

Ken> If someone could list the needed packages I would much appreciate
Ken> it.

The problem is that gcc3 generated libraries requires gcc3 compiled
stuff everywhere. Don't try glibc with gcc3 right now.

Jes

