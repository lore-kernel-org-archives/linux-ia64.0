From: William Lee Irwin III <wli@holomorphy.com>
Date: Wed, 17 Sep 2003 22:34:27 +0000
Subject: Re: [Discontig-devel] [PATCH] fix build_zonelists for CONFIG_ACPI_NUMA
Message-Id: <marc-linux-ia64-106383801220397@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Sep 17, 2003 at 02:31:58PM -0700, Jesse Barnes wrote:
> Here's a ugly little patch to make build_zonelists use the ACPI SLIT
> table on ia64 if it's present.  Comments?  Should we have a generic
> Linux distance table that we use for this?  That way people could
> populate it at early boot and we could make this code work for all
> platforms.
> Btw, this patch sits on top of the last discontig patch I posted.

I say we take this verbatim for the time being and put in the generic
table later, once there are more boxen that can use it.


-- wli
