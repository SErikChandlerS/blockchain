<template>
  <div>
    <h1>Decentralized MarketplacePage</h1>

    <div>
      <h2>Add Product</h2>
      <form @submit.prevent="addProduct">
        <label for="name">Name:</label>
        <input v-model="newProduct.name" type="text" required />

        <label for="price">Price (ETH):</label>
        <input v-model.number="newProduct.price" type="number" required />

        <label for="quantity">Quantity:</label>
        <input v-model.number="newProduct.quantity" type="number" required />

        <button type="submit">Add</button>
      </form>
    </div>

    <hr />

    <div>
      <h2>Products</h2>
      <table>
        <thead>
          <tr>
            <th>ID</th>
            <th>Name</th>
            <th>Price</th>
            <th>Quantity</th>
            <th>Seller</th>
            <th>Action</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="product in products" :key="product.id">
            <td>{{ product.id }}</td>
            <td>{{ product.name }}</td>
            <td>{{ product.price }}</td>
            <td>{{ product.quantity }}</td>
            <td>{{ product.seller }}</td>
            <td>
              <input v-model.number="purchase.quantity" type="number" :max="product.quantity" />
              <button @click="purchaseProduct(product.id)">Buy</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
import Web3 from 'web3';
import MarketplaceContract from '@/contracts/MarketplacePage.json';

export default {
  data() {
    return {
      web3: null,
      MarketplacePage: null,
      account: null,
      newProduct: {
        name: '',
        price: null,
        quantity: null,
      },
      products: [],
      purchase: {
        quantity: null,
      },
    };
  },
  async created() {
    await this.loadWeb3();
    await this.loadContract();
    await this.loadAccount();
    await this.loadProducts();
  },
  methods: {
    async loadWeb3() {
      if (window.ethereum) {
        this.web3 = new Web3(window.ethereum);
        await window.ethereum.enable();
      } else if (window.web3) {
        this.web3 = new Web3(window.web3.currentProvider);
      } else {
        console.log('Non-Ethereum browser detected. You should consider trying MetaMask!');
      }
    },
    async loadContract() {
      const networkId = await this.web3.eth.net.getId();
      const deployedNetwork = MarketplaceContract.networks[networkId];
      if (deployedNetwork) {
        this.MarketplacePage = new this.web3.eth.Contract(
          MarketplaceContract.abi,
          deployedNetwork.address,
        );
      } else {
        console.log('MarketplacePage contract not deployed to the detected network.');
      }
    },
    async loadAccount() {
      const accounts = await this.web3.eth.getAccounts();
      this.account = accounts[0];
    },
    async loadProducts() {
      const productCount = await this.MarketplacePage.methods.productCount().call();
      this.products = [];
      for (let i = 1; i <= productCount; i++) {
        const product = await this.MarketplacePage.methods.products(i).call();
        this.products.push(product);
      }
    },
    async addProduct() {
      const { name, price, quantity } = this.newProduct;
      await this.MarketplacePage.methods.addProduct(name, price, quantity).send({ from: this.account });
      this.newProduct.name = '';
      this.newProduct.price = null;
      this.newProduct.quantity = null;
      await this.loadProducts();
    },
    async purchaseProduct(productId) {
      const { quantity } = this.purchase;
      await this.MarketplacePage.methods.purchaseProduct(productId, quantity).send({ from: this.account, value: 0 });
      this.purchase.quantity = null;
      await this.loadProducts();
    },
  },
};
</script>

<style scoped>
h1 {
  font-size: 24px;
  margin-bottom: 16px;
}

h2 {
  font-size: 20px;
  margin-bottom: 8px;
}

form {
  margin-bottom: 16px;
}

label {
  display: block;
  margin-bottom: 8px;
}

input[type='text'],
input[type='number'] {
  width: 200px;
  margin-bottom: 8px;
}

table {
  width: 100%;
  border-collapse: collapse;
}

th,
td {
  padding: 8px;
  border-bottom: 1px solid #ddd;
}

button {
  padding: 4px 8px;
}
</style>