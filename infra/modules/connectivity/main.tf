resource "aws_vpc_peering_connection" "this" {
  count       = var.peer_vpc_id != "" ? 1 : 0
  vpc_id      = var.vpc_id
  peer_vpc_id = var.peer_vpc_id
  auto_accept = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-peering"
  })
}
