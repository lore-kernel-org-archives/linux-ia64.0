From: Aaron Burt <aaron@osdl.org>
Date: Fri, 05 Apr 2002 23:35:35 +0000
Subject: Re: [Linux-ia64] EMP/IPMI and Lion
Message-Id: <marc-linux-ia64-105590701905398@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805842@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805842@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 15 Jan 2002, Egan Ford wrote:
> Has anyone made use of the IPMI/BMC/EMP hardware on the Lion (4-way SMP)
> boxes with Linux?  Looking for links, tip, or hints.

Sorry to reply to a stale message, but I just tested VACM's EMP module on
our four Lions (2 from HP, 2 from IBM).  Works fine, or at least as well
as VACM ever works. http://vacm.sourceforge.net/

You do have to use the smConfig utility to enable the EMP.

If anyone's aware of any other Linux utilities that talk EMP, I'd be very
interested.


