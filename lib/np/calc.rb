module Np
  class Calc
    def calculate(text)
      targets = Np::NattoWrapper.np_nodes(text)

      targets.each do |target|
        negative_count = 0
        # negative_result =
        positive_count = 0
        # positive_result =

      end
    end

    def test
      p "!!!!!!!!!!!!!!!"
    end
  end
end
