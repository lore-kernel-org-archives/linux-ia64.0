From: "H. J. Lu" <hjl@lucon.org>
Date: Thu, 09 Sep 2004 20:13:21 +0000
Subject: Hanging process on SMP machines?
Message-Id: <20040909201321.GA21492@lucon.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux kernel <linux-kernel@vger.kernel.org>, linux ia64 kernel <linux-ia64@vger.kernel.org>

I notice that a process may hang on SMP machines at random:

http://bugzilla.kernel.org/show_bug.cgi?id332

I can reliably trigger it within 15 minutes under SMP kernel on P4 HT
and 4-way ia64 machines. Has anyone else seen it?


H.J.
