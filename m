From: Bill Nottingham <notting@redhat.com>
Date: Tue, 03 Oct 2000 00:26:15 +0000
Subject: [Linux-ia64] Re: gcc bug (2.9-ia64-000216-final)
Message-Id: <marc-linux-ia64-105590678205538@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Steve Tynor (tynor@atlanta.twr.com) said: 
> Can someone verify that this bug is fixed in the latest toolchain?

Works for me. A quick glance at the code makes me think that building
with -fno-optimize-sibling-calls will work around it for now.

Bill

