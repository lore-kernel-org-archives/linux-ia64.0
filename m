From: Fenghua Yu <fenghua.yu@intel.com>
Date: Fri, 08 Dec 2006 23:48:28 +0000
Subject: [PATCH 0/5] Itanium MC Error Injection Tool: Introduction
Message-Id: <20061208154828.A1096@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Itanium Machine Check (MC) error inject tool is used to inject MC errors
from Linux. The tool is a test bed for Itanium MC work flow including
hardware correctable error handling, OS recoverable error handling, MC
event logging, etc. The tool includes two parts: a kernel driver and a
user application sample.

The driver provides pal_mc_error_inject() interface to inject error and
query error injection capabilities.

The application sample provides a combination of various errors and calls
the drivers interface (sysfs interface) to inject errors or query error
injection capabilities. The sample application can be re-written, modified,
or integrated into other applications as long as GPL permitted.

Thanks.

-Fenghua

[PATCH 1/5] Itanium MC Error Injection Tool: Kernel configuration
[PATCH 2/5] Itanium MC Error Injection Tool: Doc and sample application
[PATCH 3/5] Itanium MC Error Injection Tool: Driver sysfs interface
[PATCH 4/5] Itanium MC Error Injection Tool: Makefile changes
[PATCH 5/5] Itanium MC Error Injection Tool: pal_mc_error_inject() interface
