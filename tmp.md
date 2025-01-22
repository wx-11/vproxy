# vproxy 使用文档：扩展功能和 CIDR Range 优化

本文档详细描述了 `vproxy` 的扩展功能，特别是 `Range` 扩展的高级用法和优化改动。

---

## 功能概览

`vproxy` 提供了多个扩展功能，以灵活控制客户端 IP 的分配和使用：

- **TTL 扩展**：基于请求次数控制 IP 变更。
- **Session 扩展**：基于固定会话 ID 分配相同的 IP。
- **Range 扩展**：在固定的 CIDR 范围内生成 IP。

---

## Range 扩展功能优化

`Range` 扩展允许通过特定范围和 ID 在动态地址分配中保持一致性，同时增强了 IP 地址的随机化生成逻辑。

### **优化代码逻辑**
在 `assign_ipv4_with_range` 和 `assign_ipv6_with_range` 中对 CIDR Range 参数进行了改进：
- 引入了 `combined` 值，允许根据 `Range` ID 的哈希值影响地址分配。
- 保留了 CIDR 的网络部分，随机化主机部分，确保分配的地址在指定范围内。
- 增加了对范围长度的验证，避免超出基础 CIDR 定义的限制。

### **关键代码片段**
#### IPv4 地址分配优化
```rust
fn assign_ipv4_with_range(cidr: &Ipv4Cidr, range: u8, combined: u32) -> Ipv4Addr {
    let base_ip: u32 = u32::from(cidr.first_address());
    let prefix_len = cidr.network_length();

    if range < prefix_len {
        return assign_rand_ipv4(cidr);
    }

    let combined_shifted = (combined & ((1u32 << (range - prefix_len)) - 1)) << (32 - range);
    let subnet_mask = !((1u32 << (32 - prefix_len)) - 1);
    let subnet_with_fixed = (base_ip & subnet_mask) | combined_shifted;

    let host_mask = (1u32 << (32 - range)) - 1;
    let host_part: u32 = random::<u32>() & host_mask;

    Ipv4Addr::from(subnet_with_fixed | host_part)
}
```

#### IPv6 地址分配优化
```rust
fn assign_ipv6_with_range(cidr: &Ipv6Cidr, range: u8, combined: u128) -> Ipv6Addr {
    let base_ip: u128 = cidr.first_address().into();
    let prefix_len = cidr.network_length();

    if range < prefix_len {
        return assign_rand_ipv6(cidr);
    }

    let combined_shifted = (combined & ((1u128 << (range - prefix_len)) - 1)) << (128 - range);
    let subnet_mask = !((1u128 << (128 - prefix_len)) - 1);
    let subnet_with_fixed = (base_ip & subnet_mask) | combined_shifted;

    let host_mask = (1u128 << (128 - range)) - 1;
    let host_part: u128 = (random::<u64>() as u128) & host_mask;

    Ipv6Addr::from(subnet_with_fixed | host_part)
}
```

---

## **高级用法**

### **TTL 扩展**
- 用户名附加格式：`username-ttl-<固定值>`。
- 每次请求后减少 TTL，达到 0 时更换 IP。
- 示例：
  ```bash
  curl -x "http://test-ttl-2:test@127.0.0.1:8101" https://ifconfig.co
  ```

### **Session 扩展**
- 用户名附加格式：`username-session-<固定ID>`。
- Session ID 保持不变时，IP 保持一致。
- 示例：
  ```bash
  curl -x "http://test-session-123456:test@127.0.0.1:8101" https://ifconfig.co
  ```

### **Range 扩展**
- 用户名附加格式：`username-range-<固定ID>`。
- 配合 `--cidr-range` 参数使用，ID 控制范围内地址生成。
- 示例：
  ```bash
  vproxy run --bind 127.0.0.1:8101 -i 2001:470:70c6::/48 --cidr-range 64 http -u test -p test

  curl -x "http://test-range-987654:test@127.0.0.1:8101" https://ifconfig.co
  ```

---

## 示例用法

### 带用户名和密码的 Http 代理会话

- 启动 `vproxy` 服务：
  ```bash
  vproxy run --bind 127.0.0.1:8101 -i 2001:470:70c6::/48 http -u test -p test
  ```

- 使用相同 Session ID：
  ```bash
  for i in `seq 1 10`; do
    curl -x "http://test-session-123456789:test@127.0.0.1:8101" -L https://ifconfig.co
  done
  ```
  输出示例：
  ```
  2001:470:70c6:93ee:9b7c:b4f9:4913:22f5
  2001:470:70c6:93ee:9b7c:b4f9:4913:22f5
  ```

- 使用不同 Session ID：
  ```bash
  for i in `seq 1 10`; do
    curl -x "http://test-session-987654321:test@127.0.0.1:8101" -L https://ifconfig.co
  done
  ```
  输出示例：
  ```
  2001:470:70c6:41d0:14fd:d025:835a:d102
  2001:470:70c6:41d0:14fd:d025:835a:d102
  ```

---

## 注意事项

1. **CIDR 范围设置**：
   - `--cidr-range` 的值应大于或等于基础 CIDR 的前缀长度。例如：
     - 基础 CIDR 为 `/48`，则 `--cidr-range` 的值需为 48 到 128 之间。

2. **扩展值使用**：
   - 确保 `Range` 或 `Session` 的 ID 值唯一且固定，以获得一致的 IP 地址。

3. **随机性与固定性平衡**：
   - 在需要动态地址时，可以不附加扩展值，让代理随机分配地址。

---

此优化提升了 Range 扩展的灵活性，增强了地址生成的一致性和安全性，同时保持了代理服务的高性能和可扩展性。
