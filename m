From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 07 Feb 2006 06:43:52 +0000
Subject: RE: [PATCH]Fix wrong use of memparse in efi.c
Message-Id: <B05667366EE6204181EABE9C1B1C0EB50997CE91@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1139283346.8654.17.camel@linux-znh>
In-Reply-To: <1139283346.8654.17.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Zou Nan hai wrote on Monday, February 06, 2006 7:36 PM
> The check of (end != cp) after memparse in efi.c looks wrong to me.
> The result is that we can't use mem= and max_addr= kernel parameter at
> the same time.

Why do you want to use both parameters at the same time?  mem= limits
maximum logical memory size while max_addr= limits maximum physical
address used in the system. It sounds wired, but people are creative...

- Ken
