From: "Luck, Tony" <tony.luck@intel.com>
Date: Sat, 08 Nov 2003 01:15:46 +0000
Subject: RE: [RFC] Better MCA recovery on IPF
Message-Id: <marc-linux-ia64-106825470428121@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106724227826901@msgid-missing>
In-Reply-To: <marc-linux-ia64-106724227826901@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I can estimate what the procedure includes, such as changing 
> poisoned memory to uncacheable, clearing suspect data in cache, and storing 
> zeros to the poisoned area.

There is no way to tell if the error is soft/transient
and can be cleared by that sequence, or hard/permanent.

The safest option is to simply take the page with
the error out of service and not re-use it.

-Tony
