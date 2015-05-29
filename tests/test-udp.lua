return require('lib/tap')(function (test)

  test("udp echo server and client", function (print, p, expect, uv)
    local server = uv.new_udp()
    local client = uv.new_udp()
    local host = "127.0.0.1"
    assert(uv.udp_bind(server, host, 0))
    assert(uv.udp_bind(client, host, 0))

    local s_address = uv.udp_getsockname(server)
    p({server=server,address=s_address})
    
    local c_address = uv.udp_getsockname(client)
    p({client=client,address=c_address})

    local i = 0
    local packets = {'asdf','qwer','exit'}

    local send = function()
      i = i + 1
      uv.udp_send(client, packets[i], s_address.ip, s_address.port)
    end

    uv.udp_recv_start(client,function(err, msg, rinfo, flags)
      p(err,msg,rinfo,flags)
      assert(packets[i] == msg)
      if msg == 'exit' then
        uv.udp_recv_stop(client)
        uv.close(client)
      end
    end)

    uv.udp_recv_start(server,function(err, msg, rinfo, flags)
      p(err,msg,rinfo,flags)
      assert(packets[i] == msg)
      if msg == 'exit' then
        uv.udp_recv_stop(client)
        uv.close(client)
      end
      uv.udp_send(server, msg, rinfo.ip, rinfo.port)
    end)

    send()
  end)

end)
