From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 02 Jun 2003 17:00:28 +0000
Subject: RE: [Linux-ia64] [PATCH] MCA recovery for TLB faults for 2.4
Message-Id: <marc-linux-ia64-105590723706109@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723706058@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723706058@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Are you just blindly trusting that memory is still correct after
> getting a TLB error report?  Wouldn't you want to have a checksum to
> validate that the list of saved translations is probably correct.
> Otherwise, it seems to me the TLB purge could make a bad situation
> worse.

At the moment the trust level is extremely high.  Linux doesn't
even provide a checksum for the ia64_os_mca_dispatch entry code
when it registers it with the SAL.

A checksum in the list of saved translations would only be part
of reducing the level of trust ... we'd also need to validate
that the entire code path has the correct code (not just the entry
point).  There are several other data items on which the code
also relies which a truly paranoid MCA handler would also need to
validate.

-Tony

