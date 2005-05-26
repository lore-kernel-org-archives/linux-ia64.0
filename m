From: "Seth, Rohit" <rohit.seth@intel.com>
Date: Thu, 26 May 2005 17:39:39 +0000
Subject: RE: flush_icache_range
Message-Id: <01EF044AAEE12F4BAAD955CB7506494303A3D9C2@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4236D7B5.8050408@bull.net>
In-Reply-To: <4236D7B5.8050408@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger <> wrote on Thursday, May 26, 2005 10:22 AM:

> BTW: I would prefer if we picked up the stride from the PAL info.
> That way, we don't have to add ugly #ifdef's and hope that we get the
> right stride.  I just checked on a Madison and, indeed it reports:
> 

Just want to confirm that this is the correct expectation.  Stride size
(as given by pal_cache_info) is the minimal number of bytes that will be
flushed using fc.

