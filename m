From: "Karthik Gopalakrishnan" <karthik.g.krishnan@gmail.com>
Date: Mon, 08 Jan 2007 12:53:45 +0000
Subject: efi.get_variable causing Oops
Message-Id: <5e0a1fd80701080453i203f866dp305dd8de664525dd@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Folks.

    I am calling the following function as the last function in
setup_arch() [well after efi_init()] on a 2.6.19 kernel.

void __init func_foo (void)
{
    unsigned char       data[1024];
    unsigned long       size = sizeof(data);
    char                *Ascii_String;
    efi_char16_t        *Unicode_String;
    char                mode_name[] = "variable_name";
    efi_char16_t        mode_name_utf[32];
    efi_guid_t          guid = CONFIG_GUID;
    efi_status_t        status;
    int                 i;

    Unicode_String = mode_name_utf;
    Ascii_String   = mode_name;
    while (*Ascii_String)
        *Unicode_String++ = *Ascii_String++ & 0x7F;
    *Unicode_String = 0;

    status = efi.get_variable(mode_name_utf, &guid, NULL, &size, data);
    ...
    ...
    ...
}

    The get_variable call is causing an Oops.

Unable to handle kernel NULL pointer dereference (address 0000000000000000)
swapper[0]: Oops 11012296146944 [2]

    Can someone tell me why it is page-faulting? Any suggestions as to
where to start looking?

Thanks & Regards,
Karthik
