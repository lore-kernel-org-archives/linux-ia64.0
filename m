From: "Yu, Fenghua" <fenghua.yu@intel.com>
Date: Tue, 26 Jun 2007 00:04:01 +0000
Subject: RE: intercept trap when running a 32bit binary
Message-Id: <79E93560F4A5FD42BB769DAAF8BEF62A01E09F7C@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070625221349.GA25054@bsd.hu>
In-Reply-To: <20070625221349.GA25054@bsd.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Program terminated with signal 11, Segmentation fault.

>#0  0x40c79b0b in global constructors keyed to date () from
>bin/engine_i686.so

>#0  0x40c79b0b in global constructors keyed to date () from
>bin/engine_i686.so
>No symbol table info available.
If you can build code with symbol info, you can map the failure point to
source code and analyze the source code.

Thanks.

-Fenghua
