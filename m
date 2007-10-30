From: Rick Jones <rick.jones2@hp.com>
Date: Tue, 30 Oct 2007 17:36:03 +0000
Subject: re: [PATCH] ia64: Fix incorrect return value from ia64_setup_msi_irq()
Message-Id: <47276B83.5050603@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4726D6DD.9090300@jp.fujitsu.com>
In-Reply-To: <4726D6DD.9090300@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Someone just pointed me at the patch mentioned in:

http://marc.info/?l=linux-ia64&m9372797223157&w=2

I can confirm that patch does good things for me - I was having problems with 
enabling MSI-X on an s2io-driven NIC before applying the patch to a 2.6.24-rc1 
tree.  With the patch in place that problem is gone.  So, if the patch can make 
-rc2 that would be goodness.

rick jones
