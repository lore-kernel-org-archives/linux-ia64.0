From: "Jon R. Doyle" <marsaro@interearth.com>
Date: Mon, 28 Oct 2002 00:14:29 +0000
Subject: [Linux-ia64] NFS on 64
Message-Id: <marc-linux-ia64-105590709805265@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I am setting up a dozen or so systems that will need to fetch users prefs
from a NFS mount point. These will be 32bit servers, but the directory
servers where these prefs are will be running Linux on Itanium2. These 64bit
servers I intend to export (NFS) out to the 32bit servers; is there anything
I should be aware of in this config? Can 32bit systems write to theat NFS
export, and compatibility switch or option flags I need to know about?


Regards,

Jon


