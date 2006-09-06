From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 06 Sep 2006 17:44:38 +0000
Subject: RE: Oops in pdflush
Message-Id: <000001c6d1dc$2014c440$e234030a@amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <je4qtl7u44.fsf@sykes.suse.de>
In-Reply-To: <je4qtl7u44.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

D.N.Jagannathan wrote on Wednesday, September 06, 2006 6:27 AM
> can anybody explain what is and the importance of pdflush process 
> running in Linux.

pdflush is a kernel thread that periodically flushing dirty pages in
page cache in order to ensure in-memory data are consistent with disk
storage.

- Ken
