From: Umut Aymakoglu <umuta@us.ibm.com>
Date: Mon, 13 Oct 2003 18:01:47 +0000
Subject: libunwind question
Message-Id: <marc-linux-ia64-106606816410248@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org





Hi -
   During unwinding is there a way to tell  if the ip is from a shared
library or from an executable and get the name of the object it is from?

 I use the unw_get_proc_name() call to get the symbol name but would like
to get the name of the object as well.

thanks,
Umut

