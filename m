From: Bill Nottingham <notting@redhat.com>
Date: Wed, 13 Dec 2000 20:14:22 +0000
Subject: [Linux-ia64] Re: agp with bigsur
Message-Id: <marc-linux-ia64-105590678205826@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Holger Berger (berger@ehpctc1.nec.tz.uni-stuttgart.de) said: 
> did anybody succeed in building and using agp kernel module?
> Is anybody working on AGP support for the chipset?
> Or does anybody know if it is possible to get hardware accelerated
> 3D graphics with this ATI card (with Linux, of course...)?

DRI has been implemented; the Voodoo support works. As for the ATI,
the last time I tried, it was making some incorrect assumptions
about the pagesize, but that was a good 4-5 months ago, I believe.

Bill

