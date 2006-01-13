From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 13 Jan 2006 20:23:28 +0000
Subject: RE: Preserving CMC/CPE records across reboot
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F056BA56C@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <14947.1137113189@ocs3.ocs.com.au>
In-Reply-To: <14947.1137113189@ocs3.ocs.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>   Sorry, it's been a while since I've looked at this code, but how do
>we determine how many records can be stored in NVRAM?  I would guess
>that for CPEs at least, it's platform dependent.  If it can be done w/o
>losing records, it's probably ok, but I'm not sure I understand the
>details.  Thanks,

Agreed.  The SAL spec doesn't require any particular capacity for
NVRAM, nor does it provide a mechanism to discover it.

-Tony
